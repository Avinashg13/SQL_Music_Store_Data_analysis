--Q1: Who is the most senior employee based on job title?

Select * from employee
Order by levels desc
limit 1

--Which Country has most number of invoices?
Select Count(*), billing_country
From invoice
group by billing_country
order by billing_country desc

--What are top  the 3 values of invoices?
Select total From invoice
Order by total desc
limit 3

--Which city has the best customers? We would like to through ; a promotional Music Festival in the city 
--we made the most money
-- write a query that returns one city that has the highest sum q Return both the city name & sum of all invoice totals

Select Sum(total) as invoice_total, billing_city  from invoice
group by billing_city
order by invoice_total desc

--Who is the best customer? 
--The customer who spend money will be declared the best customer. 
--Write a the person who has spent the most money.

Select Customer.customer_id,customer.first_name, Customer.last_name,SUM(invoice.total) as total 
From Customer
Join invoice
On Customer.customer_id = invoice.customer_id
group by Customer.customer_id
Order by total desc
limit 1


--Question Set 2 - Moderate

--Q1: Write query to return the email, first name, last name, & Genre
--of all Rock Music listeners. Return your list ordered alphabetically
--by email starting with A

Select first_name, last_name, email 
from customer
Join invoice On Customer.Customer_id = invoice.Customer_id
Join invoice_line on Invoice.invoice_id = invoice_line.invoice_id
Where track_id In(
Select track_id from track
	Join genre On track.genre_id =  genre.genre_id
	where genre.name like 'Rock'
)
order by email asc

--Q2 Let's invite the artists who have written the most rock music in
--our dataset. Write a query that returns the Artist name aad. total
--track count of the top 10 rock bands
 
 Select artist.artist_id, artist.name, count(artist.artist_id) as Number_of_songs
 from track
 Join album on album.album_id = track.album_id 
 Join artist on artist.artist_id = album.artist_id
 Join genre on genre.genre_id = track.genre_id
 where genre.name like 'Rock'
group by artist.artist_id
Order by Number_of_songs desc
limit 10

--Return all the track names that have a song length longer than the average song length. 
--Return the Name and milisecond for each track. 
--Order by the song length with the long

Select name, milliseconds 
from track
where milliseconds > (
 Select avg(milliseconds) as avg_track_length
	from track)
 Order by milliseconds desc
 
 --Find how much amount spent by each customer on artists? 
 --Write a query to return customer name, artist name and total spent
 
 with best_selling_artist AS (
	 Select artist.artist_id as artist_id,artist.name as artist_name,
	 SUM(invoice_line.unit_price*invoice_line.quantity) as total_sales
	 from invoice_line
	 Join track on track.track_id = invoice_line.track_id
	 Join album on album.album_id = track.album_id
	 Join artist on artist.artist_id = album.artist_id
	 group by 1
	 Order by 3 desc
	 limit 1  
)
Select c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) as amount_spent
from invoice
Join Customer c on C.customer_id = invoice.customer_id
Join invoice_line il on il.invoice_id = invoice.invoice_id
Join track t on t.track_id = il.track_id
Join album alb on alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
group by 1,2,3,4
Order by 5 desc;
 
--We want to find out the most popular music Genre for each country.
--We determine the most popular genre as the genre with the highest amount of purchases.
--Write a query that returns each country along with the top Genre. 
--For countries where the maximum number of purchases is shared return all Genres.

With Popular_genre as(
	Select count(invoice_line.quantity) as Purchase, customer.country, genre.name, genre.genre_id,
	row_number() Over(Partition by Customer.country Order by count(invoice_line.quantity)desc) as RowNo
	from Invoice_line
	Join invoice on invoice.invoice_id = invoice_line.invoice_id
	Join Customer on customer.customer_id = invoice.customer_id
	Join track on track.track_id = invoice_line.track_id
	Join genre on genre.genre_id = track.genre_id
	Group by 2,3,4
	Order by 2 ASC, 1 Desc
	)
Select* from Popular_genre where RowNo <= 1
 
 
--Write a query that determines the customer that has on music for each country.
--Write a query that returns the with the top customer and how much they spent. 
--For co the top amount spent is shared, provide all customers with amount
 
 With customer_with_country as (
Select customer.customer_id, first_name,last_name,billing_country,SUM(total) as total_spending,
Row_Number() Over(Partition by billing_country Order by Sum(Total)desc) as RowNo
	 from Invoice
	 Join Customer on Customer.customer_id = invoice.customer_id
	 group by 1,2,3,4
	 Order by 4 asc, 5 desc)
Select * from customer_with_country where RowNo <=1