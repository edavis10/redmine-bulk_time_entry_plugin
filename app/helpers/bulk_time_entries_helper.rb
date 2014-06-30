module BulkTimeEntriesHelper
  # Cheap knock off of the tabular form builder's labeling
  def label_for_field(field, rnd_id, options = { })
    label_text = l(options[:label]).html_safe if options[:label]
    label_text ||= l(("field_"+field.to_s.gsub(/\_id$/, "")).to_sym).html_safe
    label_text += content_tag(:span, ' *'.html_safe, :class => 'required'.html_safe) if options.delete(:required)
    label = content_tag(:label, label_text,
      :class => (@object && @object.errors.has_key?(field) ? 'error'.html_safe : nil),
      :for => (@object_name.to_s + "_" + rnd_id.to_s + "_" + field.to_s).html_safe)
    label
  end
  
  def grouped_options_for_issues(issues)
    closed_issues, open_issues = *issues.partition {|issue| issue.closed?}

    html = '<option></option>'.html_safe
    unless open_issues.empty?
      html << labeled_option_group_from_collection_for_select(:label_open_issues, open_issues)
    end

    unless closed_issues.empty?
      html << labeled_option_group_from_collection_for_select(:label_closed_issues, closed_issues)
    end
    html
  end

  def labeled_option_group_from_collection_for_select(label, collection)
    html = "<optgroup label='#{l(label)}'>".html_safe
    html << options_from_collection_for_select(collection, :id, :to_s)
    html << '</optgroup>'.html_safe
    html
  end

  def get_issues(project_id)
    project = BulkTimeEntriesController.allowed_project?(project_id)
    if project
      project.issues.all(:order => 'id ASC')
    else
      []
    end
  end
end
