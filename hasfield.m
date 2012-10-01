function result = hasfield(struct, field_name)
result = sum(strcmp(fields(struct),field_name));