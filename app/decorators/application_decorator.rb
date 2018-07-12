class ApplicationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  delegate_all
  
  def created_on
    created_at.strftime("%A, %B %e, %Y, at %l:%M %p")
  end

  def last_modified
    updated_at.strftime("Last modified on %A, %B %e, %Y, at %l:%M %p")
  end
end
