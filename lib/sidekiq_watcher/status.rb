module SidekiqWatcher
  class Status
    ALIVE = 1
    ALERT = -1
    DEAD  = -2
    DEFAULT = 0

    def self.get_type(value)
      {
        '-2' => 'DEAD',
        '-1' => 'ALERT',
        '0' => 'DEFAULT',
        '1' => 'ALIVE'
      }[value]
    end
  end
end
