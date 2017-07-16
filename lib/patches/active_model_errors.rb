module ActiveModel::Validations::HelperMethods
  # Join error messages. e.g., "Title can't be blank, Account can't be blank"
  def error_messages_formatted
    errors.full_messages.uniq.join(", ")
  end
end
