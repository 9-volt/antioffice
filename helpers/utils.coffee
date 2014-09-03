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

  dateDiff: (date1, date2)->
    seconds1 = Math.floor(date1.getTime()/1000)
    seconds2 = Math.floor(date2.getTime()/1000)

    seconds: seconds2 - seconds1
    minutes: Math.ceil((seconds2 - seconds1)/60)
    hours: Math.ceil((seconds2 - seconds1)/3600)

  newDateMinusSeconds: (seconds)->
    new Date(Date.now() - seconds * 1000)

  barrier: (count, cb)->
    cb() if count is 0

    # callback will be executed after this function was called count times
    return ()->
      count--
      cb() if count is 0
      return count
