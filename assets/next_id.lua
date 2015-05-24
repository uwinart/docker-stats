-- Функция возвращает следующий ID для первичного ключа указанного спейса
function next_id(space) -- {{{
  local s = box.space[space]
  local key = s.name .. '_max_id'
  local _schema = box.space._schema
  local tuple = _schema:get{key}
  local next_id

  if tuple == nil then
    _schema:insert{key, 0}
    next_id = 1
  else
    next_id = tuple[2] + 1
  end
  tuple = _schema:update({key}, {{'=', 2, next_id}})

  return next_id
end
-- }}}

if box.schema.func.exists('next_id') ~= true then
  box.schema.func.create('next_id')
  box.schema.user.grant('guest','execute','function','next_id')
end
