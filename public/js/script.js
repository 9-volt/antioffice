$(function(){
  var editableBlock = null

  $('body').on('click', '.editable', function(ev){
    ev.preventDefault()
    ev.stopPropagation()

    editBlock(this)
  })

  $('body').on('submit', '.editable form', function(ev){
    ev.preventDefault()
    ev.stopPropagation()

    closeBlock($(this).closest('.editable'))
  })

  $('body').on('click', function(ev){
    if (editableBlock !== null) {
      closeBlock(editableBlock)
    }
  })

  function editBlock(block) {
    // Check if it the same block
    if (editableBlock === block) {return}

    // If another block was edited, close it
    closeBlock(editableBlock)

    // Cache block
    editableBlock = block

    var $this = $(block)
      , $input = $this.find('input')
      , $value = $this.children('.value')

    $value.hide()
    $input.show().focus()
  }

  function closeBlock(block) {
    var $this = $(block)
      , $input = $this.find('input')
      , $value = $this.children('.value')
      , val = $input.val() || 'Undefined'

    if (val !== 'Undefined') {
      // Update text value
      $value.text(val)

      // Send data to server
      $.post('/' + $input.data('type') + '/' + $input.data('id'), {value: val})
    }

    $input.hide()
    $value.show()

    // Clear cache
    editableBlock = null
  }
})
