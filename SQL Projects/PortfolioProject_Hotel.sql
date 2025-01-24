/**
	* This is a Portfolio Project. The data analyzed if of Splendor Hotel Group

	* Your task involves a thorough analysis of a comprehensive dataset, featuring intricate details of bookings, guest demographics, distribution channels, and financial metrics. By applying your analytical prowess, we aim to extract meaningful insights that will not only inform operational improvements but also contribute to the overall success of SHG in delivering unparalleled hospitality.

	Data Dictionary:

●	Booking ID: Unique identifier for each booking.
●	Hotel: Type or name of the hotel within the Splendor Hotel Group.
●	Booking Date: Date when the booking was made.
●	Arrival Date: Date when the guests are scheduled to arrive.
●	Lead Time: Number of days between the booking date and arrival date.
●	Nights: Number of nights the guests are booked to stay.
●	Guests: Number of guests included in the booking.
●	Distribution Channel: The channel through which the booking was made (e.g., Direct, Online Travel Agent, Offline Travel Agent).
●	Customer Type: Type of customer making the booking (e.g., Transient, Corporate).
●	Country: Country of origin of the guests.
●	Deposit Type: Whether a deposit was made for the booking (e.g., No Deposit, Deposit).
●	Avg Daily Rate: Average daily rate for the booking.
●	Status: Status of the booking (e.g., Check-Out, Canceled).
●	Status Update: Date of the last status update for the booking.
●	Canceled (0/1): Binary indicator of whether the booking was canceled (1 if canceled, 0 if not canceled).
●	Revenue: Revenue generated from the booking.
●	Revenue Loss: Loss in revenue if the booking was canceled (negative value if the booking wasn't canceled).


**/
-------------------------------------------------------------------------------------------------------------------------------


-- before we start analyzing for specific objectives the project requires, let's look at the data first hand and examine before delve into proper analysis. Cleaning data

exec sp_help SplendorHotel

select top 50 *
from SplendorHotel


------------------------------------------------------	 PART ONE -------------------------------------------------------------
 -- Checking for null values 
SELECT *
FROM SplendorHotel
WHERE  null in ([Booking ID]
      ,[Hotel]
      ,[Booking Date]
      ,[Arrival Date]
      ,[Lead Time]
      ,[Nights]
      ,[Guests]
      ,[Distribution Channel]
      ,[Customer Type]
      ,[Country]
      ,[Deposit Type]
      ,[Avg Daily Rate]
      ,[Status]
      ,[Status Update]
      ,[Cancelled (0/1)]
      ,[Revenue]
      ,[Revenue Loss]
      ,[F18]
  ) -- there are no null values


  -- Reformatting the [Booking Date], [Arrival Date], [Status Update] to Date format
select [BookingDate]--, convert(date, [Booking Date])
from SplendorHotel

-- converting and updating the column [Booking Date]
update SplendorHotel
set [BookingDate] = CONVERT(date, [Booking Date])

/**
Updating the column directly doesn't seem to work, so I will create a new column in the existing table as BookingDate and set the new converted values to it.
**/
alter table splendorhotel
add [BookingDate] Date


-- converting and upding the column [Arrival Date]	;; assuming we face same issue as BookingDate let's proceed with that format straight away

alter table splendorhotel
add ArrivalDate Date

update SplendorHotel
set ArrivalDate = convert(date, [Arrival Date])


-- updating and converting the Status UPdate records with the new formatted values
alter table splendorhotel
add StatusUpdate Date

update SplendorHotel
set StatusUpdate = convert(date, [Status Update])



-- Delete old columns that have been converted
alter table splendorhotel
drop column f18

alter table splendorhotel
drop column [Booking Date]

alter table splendorhotel
drop column [arrival date]

alter table splendorhotel
drop column [status update]


---------------------------------------------------	PART TWO -----------------------------------------------------------

-- checking for distinct values
select distinct(Hotel) 
from SplendorHotel		-- there are two distinct values in hotel; Resort and City


select [Booking Date], count(*) as [Total Bookings For Day]
from SplendorHotel
group by [Booking Date]
order by 2		-- group by total number of bookings made each day


select distinct([Distribution Channel])
from SplendorHotel		-- there are 5 distinct Distribution Channel


select distinct([Customer Type])
from SplendorHotel		-- there are 4 distinct Customer Types


select distinct([Country]), count(Country) over (partition by country) as [Bookings Made From Country]
from SplendorHotel		-- there are 175 different countries ;; with each country the number of bookings made associated
order by 2,1


select count(Country)
from SplendorHotel
where Country = null


-------------------------------------------------------------------------------------------------------------------------------

 /**
	* objective 1: Booking Patterns:

- What is the trend in booking patterns over time, and are there specific seasons or months with increased booking activity?

- How does lead time vary across different booking channels, and is there a correlation between lead time and customer type?

 **/

 -- (A) analysis of booking patterns over months in all years combined
select MONTH([BookingDate]) AS [Month Of Booking], count(*) as [Total Bookings Per Month]
from SplendorHotel
group by MONTH(BOOKINGDATE)
order by 2 asc		-- group by total number of bookings made per the months of booking regardless of the year of booking



-- (B) analysis of Arrival patterns over months in all years combined
select MONTH([ArrivalDate]) AS [Arrival Month], count(*) as [Total Arrival Per Month]
from SplendorHotel
group by MONTH(ArrivalDate)	-- grouped by the total arrivals in a month of all years combined
order by 2


--- (C) analysis of booking patterns over years


--- (D) analysis of booking partterns over months and years

-- How does lead time vary across different booking channels, and is there a correlation between lead time and customer type?
select top 3 *
from SplendorHotel

select distinct([Distribution Channel]), count([Lead Time]) as [Total Count Of Channel Bookings] -- shows the total count of bookings made by a distribution channel
,sum([Lead Time]) as [Sum Of Lead], [Customer Type], round((count([lead time])/sum([lead time]))*100, 2) as [Percentage] 
from SplendorHotel
group by [Distribution Channel], [Customer Type]
order by 2 asc



select [Distribution Channel], sum([Lead Time]) over (partition by [Lead Time])
from SplendorHotel
group by [Distribution Channel], [Lead Time]
