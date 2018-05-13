psql -c 'truncate synthea'

for f in fhir/*.json; do
    echo "$f";

    echo "
    \set record \`cat \"$f\"\`

    insert into synthea (id, data) values ('$f', :'record');
" | psql
done
