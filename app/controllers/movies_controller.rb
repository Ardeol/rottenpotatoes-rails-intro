class MoviesController < ApplicationController
  
  def initialize
    super()
    @hilite = Hash.new("")
    @all_ratings = Movie.all_ratings
    @remembered_ratings = Hash.new(false)
    Movie.all_ratings.each { |r| @remembered_ratings[r] = true }
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
    session_redirect(params)
    
  # Remember the rating checkmarks (part 2 of the hw)
    rating_filter = params.key?(:ratings) ? params[:ratings].keys.delete_if {|item| !Movie.all_ratings.include?(item) } : Movie.all_ratings
    @remembered_ratings.each_key { |k| @remembered_ratings[k] = rating_filter.include?(k) }
    cur_movies = Movie.where(rating: rating_filter)
    
  # Sanitize the field first; id used by default
    params[:order] = %w{title release_date}.include?(params[:order]) ? params[:order] : 'id'
    
  # Set the session values
    session[:order] = params[:order]
    session[:ratings] = params[:ratings]
    
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
    if !p
      hashy = Hash.new
      hashy[:order] = "title"
      redirect_to movies_path(hashy)
    end
  end
  
  def session_redirect(params)
    if !params.key?(:order) || !params.key?(:ratings)
      options = Hash.new
      options[:order] = session.key?(:order) ? session[:order] : 'id'
      if session.key?(:ratings)
        options[:ratings] = session[:ratings]
      else
        r = Hash.new
        Movie.all_ratings.each { |item| r[item] = 1 }
        options[:ratings] = r
      end
      redirect_to movies_path(options)
    end
  end
  

end
