class SimplenoteMediator

  attr_accessor :simplenote

  def initialize(app)
    @app = app
    @simplenote = SimpleNoteApi2.new(login, password)
    @simplenote
  end

  # always overwrite local changes with server changes
  def pull
    note_hashes = get_note_hashes(:length=>100)

    note_hashes.each do |note_hash|
      if note_hash['deleted'] == 1
        if note=Note.find_by_simplenote_key(note_hash['key'])
          note.destroy 
        end
      else
        note=Note.find_by_simplenote_key(note_hash['key'])
        if note.blank?
          simplenote_body = simplenote.get_note(note_hash['key'])['content']
          title = parse_title(simplenote_body)

          note.destroy  if note=Note.find_by_title(title)

          Note.create!(:title => title, :body => parse_body(simplenote_body), :simplenote_syncnum => note_hash['syncnum'], :simplenote_key => note_hash['key'])
        elsif note.simplenote_syncnum < note_hash['syncnum']
          note_response = simplenote.get_note(note_hash['key'])
          note.update_attributes(:title => parse_title(note_response['content']), :body => parse_body(note_response['content']),
                                 :simplenote_syncnum => note_response['syncnum'], :modified_locally => false)
          # todo: update current window if it has note open, perhaps with an activerecord after_save callback
        end
      end
    end
  end

  def push
    Note.modified_locally.each do |note|
      if note.simplenote_key.present?
        update_hash = simplenote.update_note(note.simplenote_key, note.to_simplenote_content)
        note.update_attributes(:simplenote_syncnum => update_hash['syncnum'], :modified_locally=>false)
      else
        create_hash = simplenote.create_note(note.to_simplenote_content)
        note.update_attributes(:simplenote_syncnum => create_hash['syncnum'], :simplenote_key => create_hash['key'],
                               :modified_locally=>false)
      end
    end
  end

  def sync
    pull
    push
  end


  def parse_title(simplenote_body)
    simplenote_body[/(.*?)\n(.*)/m, 1].strip
  end

  def parse_body(simplenote_body)
    simplenote_body[/(.*?)\n(.*)/m, 2].strip
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
  def login
    'charles.finkel+test@gmail.com'
  end

  def password
    'justtesting'
  end

end