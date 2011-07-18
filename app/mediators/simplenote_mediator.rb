class SimplenoteMediator

  attr_accessor :simplenote

  def initialize(app, e=nil, p=nil)
    @app = app

    e = email if e == nil
    p = password if p == nil
    @simplenote = SimpleNoteApi2.new(e, p)
    @simplenote
  end

    # always overwrite local changes with server changes
  def pull
    note_hashes = get_note_hashes(:length=>100)

    note_hashes.each do |note_hash|
      if note_hash['deleted'] == 1
        if note=Note.find_by_simplenote_key(note_hash['key'])
          note.update_attributes(:modified_locally => false, :deleted_at => Time.now)
          @app.remove_note_from_view(note)
        end
      else
        note=Note.find_by_simplenote_key(note_hash['key'])
        if note.blank?
          note_response = simplenote.get_note(note_hash['key'])
          note = Note.create!(:title => parse_title(note_response['content']), :body => parse_body(note_response['content']), :simplenote_syncnum => note_hash['syncnum'], :simplenote_key => note_hash['key'],
                              :modified_at => Time.at(note_response['modifydate'].to_f))
          @app.add_note_to_view(note)
        elsif note.simplenote_syncnum < note_hash['syncnum']
          note_response = simplenote.get_note(note_hash['key'])
          note.update_attributes(:title => parse_title(note_response['content']), :body => parse_body(note_response['content']),
                                 :simplenote_syncnum => note_response['syncnum'], :modified_locally => false, :modified_at => Time.at(note_response['modifydate'].to_f),
                                 :deleted_at => nil)
          @app.update_note_in_view_if_present(note)
          # todo: update current window if it has note open, perhaps with an activerecord after_save callback
        end
      end
    end

  end

  def push
    Note.modified_locally.each do |note|
      if note.simplenote_key.present?
        update_data = {:content => note.to_simplenote_content, :modifydate => note.modified_at.to_f}
        update_data.merge!(:deleted => 1) if note.deleted?
        update_hash = simplenote.update_note(note.simplenote_key, update_data)
        note.update_attributes(:simplenote_syncnum => update_hash['syncnum'], :modified_locally=>false)
      else
        create_hash = simplenote.create_note({:content => note.to_simplenote_content, :modifydate => note.modified_at.to_f})
        note.update_attributes(:simplenote_syncnum => create_hash['syncnum'], :simplenote_key => create_hash['key'],
                               :modified_locally=>false)
      end
    end
  end

  def sync
    pull if @app.internet_connection?
    push if @app.internet_connection?
  end

  def parse_title(simplenote_body)
    if simplenote_body.include?("\n")
      simplenote_body[/(.*?)\n.*/m, 1].strip
    else
      simplenote_body.strip
    end
  end

  def parse_body(simplenote_body)
    if simplenote_body.include?("\n")
      simplenote_body[/.*?\n(.*)/m, 1].strip
    else
      ""
    end
  end

  def get_note_hashes(options={})
    data = []
    mark = nil
    begin
      o = options
      o.merge!(:mark => mark) if mark.present?
      index = simplenote.get_index(o)
      data += index['data']
      mark = index['mark']
    end while mark.present?

    data
  end

  private
  def email
    if ['production', 'console'].include? ENV["RNOT_ENV"]
      @app.config_hash[:simplenote][:email]
    else
      'charles.finkel+test@gmail.com'
    end
  end

  def password
    if  ['production', 'console'].include? ENV["RNOT_ENV"]
      @app.decrypted_simplenote_password
    else
      'justtesting'
    end
  end

end