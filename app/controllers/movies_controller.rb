class MoviesController < ApplicationController
  
  def initialize
    super()
    @hilite = Hash.new("")
    @all_ratings = Movie.all_ratings
    @remembered_ratings = Hash.new(false)
    Movie.all_ratings.each { |r| @remembered_ratings[r] = true }
    
    #session[:order] = 'id'
    #session[:ratings] 
  end
  
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
  # Filter by ratings, and ensure no invalid values are present
    test_redirect(params.key?(:order))
    
    rating_filter = params.key?(:ratings) ? params[:ratings].keys.delete_if {|item| !Movie.all_ratings.include?(item) } : Movie.all_ratings
    @remembered_ratings.each_key { |k| @remembered_ratings[k] = rating_filter.include?(k) }
    cur_movies = Movie.where(rating: rating_filter)
  # Sanitize the field first; id used by default
    params[:order] = %w{title release_date}.include?(params[:order]) ? params[:order] : 'id'
  # Hilite the correct th
    @hilite.clear
    @hilite[params[:order]] = "hilite"
  # Retrieve in correct order
    @movies = cur_movies.order "#{params[:order]} ASC"
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  
private
  def test_redirect(p)
    if p
      hashy = Hash.new
      hashy[:controller] = "movies"
      hashy[:action] = "index"
      hashy[:order] = "title"
      redirect_to hashy
    end
  end
  

end
