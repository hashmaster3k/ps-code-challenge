![](https://assets-global.website-files.com/5b69e8315733f2850ec22669/5b749a4663ff82be270ff1f5_GSC%20Lockup%20(Orange%20%3A%20Black).svg)
### Overall Thoughts
I thoroughly enjoyed this technical challenge! It was a challenge but I feel so ecstatic to have got it working while learning so much. 

### Challenge
1) **This requires Postgres (9.4+) & Rails(4.2+), so if you don't already have both installed, please install them.**

When creating a rails app I decided to use version 5.2.4.4 instead of 6 mainly because the newer versions of rails includes many javascript tools and dependencies which after reading through this challenge would not be needed. I have been using this version of rails throughout my projects and thus familiar with it. After inital setup I installed the gems I know I would need right away ```pry```, ```rspec-rails```, ```shoulda-matchers``` and ```activerecord-import```.

2) **Download the data file from: https://github.com/gospotcheck/ps-code-challenge/blob/master/Street%20Cafes%202020-21.csv**

I used the ```activerecord-import``` gem to import an array of objects into the database versus saving a new object with every row parse of the CSV. This allows for a more efficient entry as only one call is being made to access and import to the database versus x (x being the number of rows in a CSV). While the provided dataset was small, large datasets can take a while to import. Thus, effcicency is key. 

3) **Add a varchar column to the table called `category`.**

Created a migration file to add the new attribute to my street_cafe resource.

Seed file: https://github.com/hashmaster3k/ps-code-challenge/blob/master/db/seeds.rb

4) **Create a view with the following columns[provide the view SQL]**
    - post_code: The Post Code
    - total_places: The number of places in that Post Code
    - total_chairs: The total number of chairs in that Post Code
    - chairs_pct: Out of all the chairs at all the Post Codes, what percentage does this Post Code represent (should sum to 100% in the whole view)
    - place_with_max_chairs: The name of the place with the most chairs in that Post Code
    - max_chairs: The number of chairs at the place_with_max_chairs
    
I've never heard of a view until this challenge. However, after reading the docs it was clear that views are a powerful tool to create a "new" table that can be used in other SQL queries. Each column was pretty easy expect for place_with_max_chairs. I definiftly struggled on this for a while. After lots of research and trying different SQL queries I was able to get it to work in its own query and I knew I needed to join the table to itself. After my initial join I found that the data wouldn't fully combine and knew immedietly that was because a INNER JOIN was only combing exact matching values. Thus, I used a LEFT OUTER JOIN to include the rest of the data.

When I was in the rails console I wanted to be able to call onto the view using ActiveRecord. Thus, I created a model but found that the schema didn't find my "table". After more research I found that the schema doesn't allow for views but a structure does. So I switched from using a schema.rb to a structure.sql and was able to get the view to work in ActiveRecord.

Testing the data was performed manually at first as the dataset was small enough. I would find where 3 or more cafes existed in a post code and check that place_with_max_chairs and max_chairs were correct and matched my results. For automated testing, I created a fixture file within my spec folder that contained half (~36) rows of data making it easier to measure. 

Link to migration: https://github.com/hashmaster3k/ps-code-challenge/blob/master/db/migrate/20210213165602_post_code_info_view.rb
Link to test: https://github.com/hashmaster3k/ps-code-challenge/blob/master/spec/database_views/post_code_info_view_spec.rb

```sql
CREATE OR REPLACE VIEW public.post_code_info AS
SELECT
  a.post_code,
  COUNT(a.post_code) AS total_count,
  SUM(a.num_chairs) AS total_chairs,
  CONCAT(ROUND(SUM(a.num_chairs) * 100.0 / (SELECT sum(num_chairs) FROM street_cafes), 2), '%') AS chairs_pct,
  MAX(b.name) as place_with_max_chairs,
  MAX(a.num_chairs) as max_chairs
FROM
  street_cafes a
LEFT OUTER JOIN
  (SELECT
    name,
    post_code,
    num_chairs
   FROM
    street_cafes
   WHERE
    (post_code, num_chairs)
   IN
    (SELECT post_code, MAX(num_chairs)
   FROM street_cafes GROUP BY post_code)) b
ON
  a.post_code = b.post_code
GROUP BY
  a.post_code;
```
<img width="617" alt="Screen Shot 2021-02-15 at 7 59 15 AM" src="https://user-images.githubusercontent.com/40395852/107962004-c60b3200-6f63-11eb-8707-9b1845799e8b.png">

    
5) **Write a Rails script to categorize the cafes and write the result to the category according to the rules:[provide the script]**
    - If the Post Code is of the LS1 prefix type:
        - `# of chairs less than 10: category = 'ls1 small'`
        - `# of chairs greater than or equal to 10, less than 100: category = 'ls1 medium'`
        - `# of chairs greater than or equal to 100: category = 'ls1 large' `
    - If the Post Code is of the LS2 prefix type: 
        - `# of chairs below the 50th percentile for ls2: category = 'ls2 small'`
        - `# of chairs above the 50th percentile for ls2: category = 'ls2 large'`
    - For Post Code is something else:
        - `category = 'other'`
	
I decided to write my own objects for testing as I only need to measure one cafe per unique category. So I created six cafes with nil value for category. I call onto the rake task within the test then expects that the objects in the database now contain their correct categories.
	
Link to script: https://github.com/hashmaster3k/ps-code-challenge/blob/master/lib/tasks/street_cafes.rake
Link to test: https://github.com/hashmaster3k/ps-code-challenge/blob/master/spec/tasks/street_cafe/categorize_spec.rb
Note: I shorted the code below to only show the script for categorization. 

```ruby
namespace :street_cafes do
  desc "Categorize empty cafes based on number of chairs"
  task categorize: :environment do
    include Statistical

    cafes = StreetCafe.where(category: nil)
    cafes_LS1 = []
    cafes_LS2 = []

    cafes.map do |cafe|
      if cafe.post_code.split(' ').first == "LS1"
        cafes_LS1 << cafe
      elsif cafe.post_code.split(' ').first == "LS2"
        cafes_LS2 << cafe
      else
        cafe.category = 'other'
        cafe.save
      end
    end

    unless cafes_LS1.empty?
      cafes_LS1.each do |cafe|
        if cafe.num_chairs >= 100
          cafe.category = 'ls1 large'
        elsif cafe.num_chairs >= 10
          cafe.category = 'ls1 medium'
        else
          cafe.category = 'ls1 small'
        end

        cafe.save
      end
    end

    unless cafes_LS2.empty?
      values = cafes_LS2.pluck(:num_chairs)
      percentile_50_LS2 = percentile(values, 0.5)

      cafes_LS2.each do |cafe|
        if cafe.num_chairs >= percentile_50_LS2
          cafe.category = 'ls2 large'
        else
          cafe.category = 'ls2 small'
        end

        cafe.save
      end
    end
  end
end
```
6) **Write a custom view to aggregate the categories [provide view SQL AND the results of this view]**
    - category: The category column
    - total_places: The number of places in that category
    - total_chairs: The total chairs in that category
    
Pretty standard query. In my test I used my fixture file to convert data from CSV into the database, I then call onto my previously built categorize task to automatically categorize the cafes. My expectation is to take all the distinct ids from StreetCafes and ensure they are grouping correctly. From there I just cross-referenced the data manually.

Link to migration: https://github.com/hashmaster3k/ps-code-challenge/blob/master/db/migrate/20210214161846_cafe_category_info_view.rb
Link to test: https://github.com/hashmaster3k/ps-code-challenge/blob/master/spec/database_views/cafe_category_info_view_spec.rb
    
```sql
CREATE OR REPLACE VIEW public.cafe_category_info AS
SELECT
  category,
  COUNT(*) AS total_places,
  SUM(num_chairs) AS total_chairs
FROM
  street_cafes
GROUP BY
  category
```
<img width="611" alt="Screen Shot 2021-02-14 at 10 10 23 PM" src="https://user-images.githubusercontent.com/40395852/107907818-ed391380-6f11-11eb-812e-fe9353b1e600.png">

7) **Write a script in rails to:**
    - For street_cafes categorized as small, write a script that exports their data to a csv and deletes the records
    - For street cafes categorized as medium or large, write a script that concatenates the category name to the beginning of the name and writes it back to the name column
    
These weren't particularly difficult but I did have trouble deciding where the exported CSV files should be stored after creation. I decided to create ```exported_data/street_cafes``` folders in the main directory.
	
Link to script for both: https://github.com/hashmaster3k/ps-code-challenge/blob/master/lib/tasks/street_cafes.rake
Link to test for exporting: https://github.com/hashmaster3k/ps-code-challenge/blob/master/spec/tasks/street_cafe/export_small_spec.rb
Link to test for concatenating: https://github.com/hashmaster3k/ps-code-challenge/blob/master/spec/tasks/street_cafe/concat_medium_large_cafes_spec.rb

```ruby
desc "Exports cafes with categories labeled small to a csv and deletes the records"
task export_small_cafes: :environment do
  cafes = StreetCafe.find_small_cafes
  headers = ['Café/Restaurant Name', 'Street Address', 'Post Code', 'Number of Chairs']
  file = "#{Rails.root}/exported_data/street_cafes/list_small_cafes.csv"
  file = "#{Rails.root}/spec/fixtures/list_small_cafes.csv" if Rails.env == 'test'

  CSV.open(file, 'w', write_headers: true, headers: headers) do |writer|
    cafes.each do |cafe|
      writer << [cafe.name, cafe.address, cafe.post_code, cafe.num_chairs]
    end
  end

  StreetCafe.delete_cafes(cafes)
end
```

<img width="693" alt="Screen Shot 2021-02-14 at 10 17 09 PM" src="https://user-images.githubusercontent.com/40395852/107908095-7b14fe80-6f12-11eb-9b9f-8530f29ecb55.png">

```ruby
desc "Concatenates the category to the beginning of the cafe name "
task concat_medium_large_cafes: :environment do
  cafes = StreetCafe.find_medium_large_cafes
  cafes.map do |cafe|
    cafe.name = "#{cafe.category} #{cafe.name}"
    cafe.save
  end
end
```

<img width="1433" alt="Screen Shot 2021-02-14 at 10 22 42 PM" src="https://user-images.githubusercontent.com/40395852/107908422-3d64a580-6f13-11eb-9ab5-2adc732894ee.png">

8) Show your work and check your email for submission instructions.

9) Celebrate, you did great! 


