class ObsessionDecorator < Draper::Decorator
  delegate_all

  def hypotheticalize # sets intrusive_thought attribute of obsession = formatted string
    idea = intrusive_thought.downcase.split(/\A\bwhat\b\s+\bif\b\s+\bi\b\s+/).join("").split("?").join("")
    intrusive_thought = "What if I " << "#{idea}?"
  end
end
