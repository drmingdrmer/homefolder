" add != NULL
%s/s3_must_be(\(\w\+\)\(, \w\+\)\?);/s3_must_be(\1 != NULL\2);


" add inited_ == 1
%s/s3_must_be(\(\w\+->inited_\)\(, \w\+\)\?);/s3_must_be(\1 == 1\2);


" use s3_must_inited
%s/s3_must_be(\(\w\+\) != NULL\(, \w\+\)\?);\n *s3_must_be(\1->inited_ == 1\(, \w\+\)\?);/s3_must_inited(\1, S3_ERR_UNINITED);


" use s3_must_uninited
%s/s3_must_be(\(\w\+\) != NULL\(, \w\+\)\?);\n *s3_must_be(\1->inited_ == 0\(, \w\+\)\?);/s3_must_uninited(\1, S3_ERR_INIT_TWICE);
