

form = $ "form:first"
buttons = $ ".post_buttons:first"
handleThen = (next) ->
  (evt) ->
    evt.preventDefault()
    evt.stopPropagation()

    do next if next

    false

buttons.delegate "#save", "click", handleThen ->
  do form.submit

