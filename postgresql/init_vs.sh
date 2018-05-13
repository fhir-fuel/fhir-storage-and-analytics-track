export PGUSER=postgres
export PGPORT=5777
export PGPASSWORD=postgres
export PGHOST=localhost
export PGDATABASE=synthea

psql -c 'truncate synthea'

for f in vs/*.json; do
    echo "$f";

    echo "
    \set record \`cat \"$f\"\`

    insert into synthea (id, data) values ('$f', :'record');
" | psql
done
