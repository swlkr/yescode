-- name: latest
select id, title, body, created_at
from post
order by created_at desc
limit :limit

-- name: by_pk
select *
from post
where post_id = ?
limit 1
