module BulkTimeEntriesHelper
  # Cheap knock off of the tabular form builder's labeling
  def label_for_field(field, rnd_id, options = { })
    label_text = l(options[:label]) if options[:label]
    label_text ||= l(("field_"+field.to_s.gsub(/\_id$/, "")).to_sym)
    label_text += @template.content_tag("span", " *", :class => "required") if options.delete(:required)
    label = @template.content_tag("label", label_text, 
      :class => (@object && @object.errors.on(field) ? "error" : nil), 
      :for => (@object_name.to_s + "_" + rnd_id.to_s + "_" + field.to_s))
    label
  end
  
  def grouped_options_for_issues(issues)
    open_issues = []
    closed_issues = []
    issues.each do |issue|
      if issue.closed?
        closed_issues << issue
      else
        open_issues << issue
      end
    end

    html = '<option></option>'
    unless open_issues.empty?
      html << "<optgroup label='#{l(:label_open_issues)}'>"
      html << options_from_collection_for_select(open_issues, :id, :to_s)
      html << "</optgroup>"
    end

    unless closed_issues.empty?
      html << "<optgroup label='#{l(:label_closed_issues)}'>"
      html << options_from_collection_for_select(closed_issues, :id, :to_s)
      html << "</optgroup>"
    end
    html
  end
end
