class SimplenoteMediator

  attr_accessor :simplenote

  def initialize
    @simplenote = SimpleNoteApi2.new(login, password)
    @simplenote
  end

  # always overwrite local changes with server changes
  def pull
    # first, pull in all stuff from server
    note_hashes = get_note_hashes

    # delete any notes locally that are marked as deleted on the server , update any notes locally that have newer modified times on the server, or add ones that don't exist

    note_hashes.each do |note_hash|
      if note_hash['deleted'] == 1 && note=Note.find_by_simplenote_key(note_hash['key'])
        note.destroy
      else
        note=Note.find_by_simplenote_key(note_hash['key'])
        if note.blank?
          simplenote_body = simplenote.get_note(note_hash['key'])['content']
          Note.create!(:title => parse_title(simplenote_body), :body => parse_body(simplenote_body), :simplenote_syncnum => note_hash['syncnum'], :simplenote_key => note_hash['key'])
        elsif note.simplenote_syncnum < note_hash['syncnum']
          note_response = simplenote.get_note(note_hash['key'])
          notes_to_push.delete(note) if notes_to_push.include?(note)
          note.update_attributes(:title => parse_title(note_response['content']), :body => parse_body(note_response['content']), :simplenote_syncnum => note_response['syncnum'])
          # todo: update current window if it has note open, perhaps with an activerecord after_save callback
        end
      end
    end
  end

  def push
    notes_to_push.each do |note|
      #
      if note.simplenote_key.present?
        debugger
        f = simplenote.update_note(note.simplenote_key, note.to_simplenote_content)
        g = 4
      else
# create note
      end
    end
  end

  def sync
    pull
    push
  end

  def setup_push_queue

  end

  def initial_sync
    # sets up queue
    pull
    setup_push_queue
    push

  end

  def parse_title(simplenote_body)
    simplenote_body[/(.*?)\n(.*)/m, 1].strip
  end

  def parse_body(simplenote_body)
    simplenote_body[/(.*?)\n(.*)/m, 2].strip
  end

  def notes_to_push
    @notes_to_push ||= []
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