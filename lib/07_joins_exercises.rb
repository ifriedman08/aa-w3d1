# == Schema Information
#
# Table name: actors
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: movies
#
#  id          :integer      not null, primary key
#  title       :string
#  yr          :integer
#  score       :float
#  votes       :integer
#  director_id :integer
#
# Table name: castings
#
#  movie_id    :integer      not null, primary key
#  actor_id    :integer      not null, primary key
#  ord         :integer

require_relative './sqlzoo.rb'

def example_join
  execute(<<-SQL)
    SELECT
      *
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors ON castings.actor_id = actors.id
    WHERE
      actors.name = 'Sean Connery'
  SQL
end

def ford_films
  # List the films in which 'Harrison Ford' has appeared.
  execute(<<-SQL)
    SELECT
      title
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors on castings.actor_id = actors.id
    WHERE
      actors.name = 'Harrison Ford'
  SQL
end

def ford_supporting_films
  # List the films where 'Harrison Ford' has appeared - but not in the star
  # role. [Note: the ord field of casting gives the position of the actor. If
  # ord=1 then this actor is in the starring role]
  execute(<<-SQL)
    SELECT
      title
    FROM
      movies
    JOIN
      castings ON movies.id = castings.movie_id
    JOIN
      actors on castings.actor_id = actors.id
    WHERE
      actors.name = 'Harrison Ford' AND castings.ord > 1
  SQL
end

def films_and_stars_from_sixty_two
  # List the title and leading star of every 1962 film.
  execute(<<-SQL)
    SELECT
      m.title, a.name
    FROM
      movies m
    JOIN
      castings c ON m.id = c.movie_id
    JOIN
      actors a ON c.actor_id = a.id
    WHERE
      m.yr = 1962 AND c.ord = 1
  SQL
end

def travoltas_busiest_years
  # Which were the busiest years for 'John Travolta'? Show the year and the
  # number of movies he made for any year in which he made at least 2 movies.
  execute(<<-SQL)
    SELECT
      m.yr, count(title)
    FROM
      movies m
    JOIN
      castings c ON m.id = c.movie_id
    JOIN
      (SELECT
         *
       FROM
         actors
       WHERE
         name = 'John Travolta') a ON c.actor_id = a.id
    GROUP BY
      m.yr
    HAVING
      count(title) >= 2
  SQL
end

def andrews_films_and_leads
  # List the film title and the leading actor for all of the films 'Julie
  # Andrews' played in.
  execute(<<-SQL)
    -- SELECT
    --   m.title, a.name
    -- FROM
    --   (SELECT
    --     *
    --   FROM
    --     movies
    --   WHERE
    --     id IN (SELECT
    --             movie_id
    --            FROM
    --             castings
    --            WHERE
    --             actor_id IN (SELECT
    --                           id
    --                          FROM
    --                           actors
    --                          WHERE
    --                           name = 'Julie Andrews'))) m
    --   JOIN
    --     castings c ON m.id = c.movie_id
    --   JOIN
    --     actors a ON a.id = c.actor_id
    --   WHERE
    --     c.ord = 1

    SELECT
      m.title, l_a.name
    FROM
      movies m
    JOIN
      castings j_c ON m.id = j_c.movie_id
    JOIN
      castings l_c ON m.id = l_c.movie_id
    JOIN
      actors j_a ON j_a.id =  j_c.actor_id
    JOIN
      actors l_a ON l_a.id = l_c.actor_id
    WHERE
      l_c.ord = 1 AND j_a.name = 'Julie Andrews'

  SQL
end

def prolific_actors
  # Obtain a list in alphabetical order of actors who've had at least 15
  # starring roles.
  execute(<<-SQL)
    SELECT
      a.name
    FROM
      actors a
    JOIN
      (SELECT
        *
       FROM
        castings
       WHERE
        ord = 1
       ) c ON a.id = c.actor_id
    GROUP BY
      a.name
    HAVING
      count(c.movie_id) >= 15
    ORDER BY
      a.name
  SQL
end

def films_by_cast_size
  # List the films released in the year 1978 ordered by the number of actors
  # in the cast (descending), then by title (ascending).
  execute(<<-SQL)
    SELECT
      m.title, count(c.actor_id)
    FROM
      (SELECT
        *
       FROM
        movies
       WHERE
        yr = 1978) m
    JOIN
      castings c ON c.movie_id = m.id
    GROUP BY
      m.title
    ORDER BY
      count(c.actor_id) DESC, m.title
  SQL
end

def colleagues_of_garfunkel
  # List all the people who have played alongside 'Art Garfunkel'.
  execute(<<-SQL)
    SELECT
      a_a.name
    FROM
      (SELECT
        m.*
       FROM
        movies m
       JOIN
        castings c ON c.movie_id = m.id
       JOIN
        actors a ON a.id = c.actor_id
       WHERE
        a.name = 'Art Garfunkel'
      ) a_m
    JOIN
     castings a_c ON a_c.movie_id = a_m.id
    JOIN
     actors a_a ON a_a.id = a_c.actor_id
    WHERE
      a_a.name != 'Art Garfunkel'
  SQL
end
