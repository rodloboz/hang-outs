class TimeCop
  EXP = /(?:(?:\b(?:next|this)\b\s+)?\b(?:tomorrow|month|evening|afternoon|monday|tuesday|wednesday|thursday|friday|saturday|sunday)\b(?:\s+(?:morning|afternoon|evening|night))?|\bin\b\s+\d\d?\s+(?:day|month|week)s?|(?:(?:\d\d?\s+)?\b(?:january|february|march|april|may|june|july|august|september|november|december)\b(?:\s+\d\d?)?))(?:(?:\s+at\b)\s+(?:(?:[01]\d)|2[0-4]|[1-9](?:\:[0-5]\d)?)?(?:\s+(?:am|a.m.|pm|p.m)?)?)?/i

  def initialize(text)
    @text = text
  end

  def perform
    parse_text
  end

  private

  attr_reader :text

  def scan_text
    matches = text.downcase.scan(EXP).first
    # matches.reject(&:nil?).map(&:strip).uniq.first
  end

  def parse_text
    Chronic.parse(scan_text)
  end
end
