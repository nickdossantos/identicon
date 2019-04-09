defmodule Identicon do
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
  # Did not tack on = image as and argument inside the function. Becuase we don't need the
  # left overs from the struct we only need color and pixel map to finish off the job.
  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    # creates a canvas of 250 x 250
    image = :egd.create(250, 250)
    # we create a fill obj
    fill = :egd.color(color)
    # iterate over every element
    # below this is a case where we do not create a new image, we are just modifing a created on
    # this is part of the erlang lib functionalities
    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _tail}) ->
      # rem calcuates the remainder
      rem(code, 2) == 0
    end
    %Identicon.Image{image | grid: grid}
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
     pixel_map = Enum.map grid, fn({_code, index}) ->
       horizontal = rem(index, 5) * 50
       vertical = div(index, 5) * 50

       top_left = {horizontal, vertical}
       bottom_right = {horizontal + 50, vertical + 50}
       {top_left, bottom_right}
     end
     %Identicon.Image{image | pixel_map: pixel_map}
  end

  def mirror_row(row) do
    # [145, 46,200]

    [first, second | _tail] = row

    # [145, 46, 200, 46, 145]
    row ++ [second, first]
  end

  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | color: {r,g,b}}
  end

  def hash_input(input)do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end
end
