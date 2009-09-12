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
  
  def group_by_root_for_select(projects)
    result = []
    user_projects_by_root = projects.group_by(&:root) 
    user_projects_by_root.keys.sort.each do |root| 
      result  << [h(root.name), root.id] 
      user_projects_by_root[root].sort.each do |project| 
        next if project == root 
        # result << ["&#187; #{h(project.name)}", project.id] 
        result << ["» #{h(project.name)}", project.id] 
      end 
    end
    return result
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
