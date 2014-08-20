module.exports =
  assignIds: (list, key='id')->
    # Create a list copy
    newList = list.slice()

    for i in [0...newList.length] by 1
      newList[i][key] = i

    newList
