module SerializationHelpers

  # helper to serialize in a format that would
  # be passed to the controller from a request
  # (e.g. from the client)
  def serialize(model, root=false)
    options = {}
    options[:root] = false unless root
    params = model.active_model_serializer.new(model, options).as_json
    params[:id] = model.id if root
    params
  end

  def serialize_array(arr)
    arr.map(&method(:serialize))
  end

end