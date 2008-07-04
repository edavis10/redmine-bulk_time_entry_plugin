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
end
