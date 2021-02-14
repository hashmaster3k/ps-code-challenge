class PostCodeInfoView < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        execute <<-SQL
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
        SQL
      end

      dir.down do
        execute <<-SQL
          DROP VIEW IF EXISTS public.post_code_info;
        SQL
      end
    end
  end
end
