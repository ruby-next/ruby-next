def display_name(name_hash)
  case name_hash
  in guest: true
    "Guest"
  in username:
    username
  in nickname: nickname, realname: {first:, last:}
    "#{nickname} #{first} #{last}"
  in first:, last:
    "#{first} #{last}"
  in handle: 'bart' | 'el barto'
    'Bart S.'
  else
    'New User'
  end
end

data = {
  nickname: 'Tae',
  realname: {first: 'Noppakun', last: 'Wongsrinoppakun'}
}

data2 = {
  realname: {first: 'Homer', last: 'Simpson'},
  first: 'Homey',
  last: 'Simmy'
}

p display_name data #=> "Tae Noppakun Wongsrinoppakun"
p display_name(guest: true) #=> "Guest"
p display_name data2 #=> "Homey Simmy"
p display_name(handle: 'el barto') #=> "Bart S."
