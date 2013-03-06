class ActiveSupport::TimeWithZone
    def as_json(options = {})
        strftime("%I:%M %p")
    end
end
