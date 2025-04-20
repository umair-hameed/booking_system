module BookingsHelper
  def status_badge_class(status)
    case status.to_sym
    when :pending
      "bg-warning"
    when :confirmed
      "bg-success"
    when :cancelled
      "bg-danger"
    else
      "bg-secondary"
    end
  end
end
