class SimplenoteMediator

  attr_accessor :simplenote

  def initialize
    @simplenote = SimpleNote.new
    @simplenote.login(login, password)
    @simplenote
  end

  # always overwrite local changes with server changes
  def pull
    # first, pull in all stuff from server
    note_hashes = JSON.parse(simplenote.get_index.body)

    # delete any notes locally that are marked as deleted on the server , update any notes locally that have newer modified times on the server, or add ones that don't exist

    note_hashes.each do |note_hash|
      if note_hash['deleted'] && note=Note.find_by_simplenote_key(note_hash['key'])
        note.destroy
      else
        note=Note.find_by_simplenote_key(note_hash['key'])
        if note.blank?
          simplenote_body = simplenote.get_note(note_hash['key']).body
          Note.create!(:title => parse_title(simplenote_body), :body => parse_body(simplenote_body), :simplenote_modify => note_hash['modify'], :simplenote_key => note_hash['key'])
        elsif note.simplenote_modify < DateTime.parse(note_hash['modify'])
          simplenote_body = simplenote.get_note(note_hash['key']).body
          note.update_attributes(:title => parse_title(simplenote_body), :body => parse_body(simplenote_body), :simplenote_modify => note_hash['modify'])
        end
      end
    end


  end

  def push

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

  private
  def login
    'charles.finkel+test@gmail.com'
  end

  def password
    'justtesting'
  end

end