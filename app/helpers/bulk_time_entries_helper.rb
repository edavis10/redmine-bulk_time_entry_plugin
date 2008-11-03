module BulkTimeEntriesHelper
  # Cheap knock off of the tabular form builder's labeling
  def label_for_field(field, options = { })
    label_text = l(options[:label]) if options[:label]
    label_text ||= l(("field_"+field.to_s.gsub(/\_id$/, "")).to_sym)
    label_text << @template.content_tag("span", " *", :class => "required") if options.delete(:required)
    label = @template.content_tag("label", label_text, 
      :class => (@object && @object.errors[field] ? "error" : nil), 
      :for => (@object_name.to_s + "_" + field.to_s))
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
end
