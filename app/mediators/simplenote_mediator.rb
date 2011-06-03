module SimplenoteMediator

  # always overwrite local changes with server changes
  def pull
    # first, pull in all stuff from server
    note_hashes = JSON.parse(s.get_index.body)
    note_hashes.each do |note_hash|
      DateTime.parse(note_hash['modify'])
    end

    #    simplenote.get_index # deleted, modify, key

    # delete any notes locally that are marked as deleted on the server

    # update any notes locally that have newer modified times on the server

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

  private
  def login
    'charles.finkel+test@gmail.com'
  end

  def password
    'justtesting'
  end

  def simplenote
    @simplenote ||= lambda do
      s = SimpleNote.new
      s.login(login, password)
      s
    end.call
  end
end