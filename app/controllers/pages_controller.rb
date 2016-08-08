class PagesController < ApplicationController

  def game
    @grid = generate_grid(15)
  end

  def score
    @start_time = params[:start_time]
    @end_time = Time.now
    @time_taken = @end_time - Time.parse(@start_time)
    @grid = params[:final_grid].scan(/[A-Z]/)
    @word = params[:word]
    included?(@word, @grid)
    compute_score(@word, @time_taken)
    run_game(@word, @grid, @start_time, @end_time)
    @translation = get_translation(@word)
    @results = score_and_message(@word, @translation, @grid, @time_taken)
  end

private

  def generate_grid(grid_size)
    Array.new(grid_size) { ('A'..'Z').to_a[rand(26)] }
  end



  def included?(guess, grid)
    the_grid = grid.clone
    guess.chars.each do |letter|
      the_grid.delete_at(the_grid.index(letter)) if the_grid.include?(letter)
    end
    grid.size == guess.size + the_grid.size
  end


def compute_score(attempt, time_taken)
  (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
end

def run_game(attempt, grid, start_time, end_time)
  result = { time: end_time - Time.parse(start_time) }

  result[:translation] = get_translation(attempt)
  result[:score], result[:message] = score_and_message(
    attempt, result[:translation], grid, result[:time])

  result
end

def score_and_message(attempt, translation, grid, time)
  if translation
    if included?(attempt.upcase, grid)
      score = compute_score(attempt, time)
      [score, "well done"]
    else
      [0, "not in the grid"]
    end
  else
    [0, "not an english word"]
  end
end


def get_translation(word)
  response = open("http://api.wordreference.com/0.8/80143/json/enfr/#{word.downcase}")
  json = JSON.parse(response.read.to_s)
  json['term0']['PrincipalTranslations']['0']['FirstTranslation']['term'] unless json["Error"]
end

end
