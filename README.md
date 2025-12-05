# Fcm

## Installation

If you have ruby 3.3.6 and bundle:
```
$ git clone git@github.com:ro-fdm/fcm_challenge.git
$ bundle install
$ cd lib/
$ BASED=SVQ bundle exec ruby main.rb input.txt
```
or you can use docker:
```
$ docker build fcm .
$ docker run -it fcm /bin/bash
root@number:/app# cd lib/
root@number:/app/lib# BASED=SVQ bundle exec ruby main.rb input.txt
```

## Development
### Gem
I decide to create a gem because reading the instructions looks like a terminal task that it run with this command:
```
BASED=SVQ bundle exec ruby main.rb input.txt
```
Besides this task has a simple input and output.

### Object
I decided to create a type of object, Segment, to save the information of every line with information.\
I identify two types of data, some are reservations for accomodations and other tickets for transport.\
But I prefer to begin with a one type of object and if I needed in the future split to two, instead of create two different objects in this step.\

### Group the segments in travels
I order the segments using the `departure_time`.\
Once the segments are ordered we can know the initial step of every travel because the `from` field would be the city identify by IATA that was passed like the environment variable BASED.\
To know the next steps for every travel I use a loop where I search the next step for:\
- the field `from` the next step should be the field `to` of the previous step.
- the date of arrival of the next step should be later of the departure time of the previous step.\

I use a loop because I don't know the number of steps in the travel.  

### Calculate the destination
We use the next logic:
- If the travel have an accomodation we use the city of the accomodation.

- If we don't have an accomodation and the second step is other tranport and is less than a 1 day later that the first step, we consider this a
connection and we use the city of destination of the second transport.

- If neither of the previous options happens, we use the destination of the first tranport.


## Doubts
1. I am using the number of words in the line to identify the data, then in normals conditions of work I would ask if we are sure about this.
Because if, for example, we have an hour to leave an accomodation, example:
```
"SEGMENT: Resort MAD 2023-02-15 -> 2023-02-17 12:00"
```
with the current code will raise an error.

2. In the case of transport if in the middle of the travel we change the day, that is reflected in some way?
For example:
```
SEGMENT: Flight SVQ 2023-03-02 23:40 -> BCN 02:10
```
Because if this case would be completed with more information for example:
```
SEGMENT: Flight SVQ 2023-03-02 23:40 -> BCN 2023-03-03 02:10
```
Because with the current code will raise an error.

3. When I calculate the destination, I am assuming that the travel have only one connection. If we have more than one connection the destination would not be show rightly.

## Test
I have wrote several files for testing:  
- group_data.txt we have have the three options for calculate destination:
  1. One travel with accomodation  
  2. One with connection and not accomodation
  3. One travel with only outbound journey
And we can use this files in the terminal to see the output:
```
$ cd lib/
$ BASED=MAD bundle exec ruby main.rb ../spec/group_data.txt 
```

- empty_data.txt we have a txt.file but without any right line
```
BASED=SVQ bundle exec ruby main.rb ../spec/empty_data.txt 
```

- error_data.txt we can see segments with errors in action:
```
$ BASED=SVQ bundle exec ruby main.rb ../spec/error_data.txt
```

- test_data.txt we have only part of the information of input.txt for simpler results for tests.  

Besides, I added some messages by typical errors for users, like forget the BASED environment, or the file, or use a file that is not a txt.  

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/fcm.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
