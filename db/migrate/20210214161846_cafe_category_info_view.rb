class CafeCategoryInfoView < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
          CREATE OR REPLACE VIEW public.cafe_category_info AS
          SELECT
          	category,
          	COUNT(*) AS total_places,
          	SUM(num_chairs) AS total_chairs
          FROM
          	street_cafes
          GROUP BY
          	category
        SQL
      end

      dir.down do
        execute <<-SQL
          DROP VIEW IF EXISTS public.category_info_info;
        SQL
      end
    end
  end
end
