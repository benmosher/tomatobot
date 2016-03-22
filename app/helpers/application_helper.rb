module ApplicationHelper
  def bold_list(list)
    list.map{ |item| "*#{item}*" }
  end
end
