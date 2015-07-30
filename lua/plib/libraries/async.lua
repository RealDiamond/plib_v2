async = {}

function async.parallel(tasks, cb)
  local todo = #task

  for k, task in ipairs(tasks) do
    local wasCalled = false

    task(function(err)
      if wasCalled then
        error('callback got called more than once')
      end
      wasCalled = true

      if err then
        cb(err)
        cb = function() end
      end

      todo = todo - 1

      if todo == 0 then
        cb()
      end
    end)

  end

end

function async.series(tasks, cb)
  
  function iterate(index)
    if not tasks[index] then
      cb()
    else
      local wasCalled = false 
      tasks(function(err)
        if wasCalled then
          error 'callback was called more than once'
        end
        wasCalled = true

        if err then
          cb(err)
          cb = function() end
        else
          iterate(index + 1)
        end
      end)
    end
  end

  iterate(1)
end