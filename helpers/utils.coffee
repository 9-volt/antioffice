module.exports =
  assignIds: (list, key='id')->
    # Create a list copy
    newList = list.slice()

    for i in [0...newList.length] by 1
      newList[i][key] = i

    newList

  # got from DIR-300 v2.15
  COMM_RandomStr: (len)->
    c = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    str = ''
    for i in [0..len-1]
      rand_char = Math.floor(Math.random() * c.length)
      str += c.substring(rand_char, rand_char + 1)

    return str
