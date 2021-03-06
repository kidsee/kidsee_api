defmodule KidseeApi.Schemas.Post do
  use KidseeApi.Schema
  alias KidseeApi.Schemas.{ThemeLocation, Comment, Post, PostType, Status, ContentType, User, Location}

  schema "post" do
    field :content, :string
    field :title, :string
    field :rating, :float
    field :rating_count, :integer

    belongs_to :status, Status
    belongs_to :post_type, PostType
    belongs_to :content_type, ContentType
    belongs_to :user, User
    belongs_to :location, Location

    has_many :comments, Comment
    timestamps()
  end

  def for_theme(query, nil), do: query
  def for_theme(query \\ Post, theme_id) do
    from p in query,
      join: l in assoc(p, :location),
      join: tl in ThemeLocation, on: tl.location_id == l.id,
      where: tl.theme_id == ^theme_id
  end

  def preload(query) do
    from q in query,
      preload: [
        :status, :content_type, :post_type,
        user: ^Repo.preload_schema(User),
        location: ^Repo.preload_schema(Location),
        comments: ^Repo.preload_schema(Comment, :nested)
      ]
  end

  @doc false
  def changeset(%Post{} = post, attrs) do
    post
    |> cast(attrs, [:rating, :rating_count, :title, :content_type_id, :post_type_id, :user_id, :status_id, :location_id])
    |> cast_content(post, attrs)
    |> validate_required([:content, :title, :content_type_id, :user_id, :status_id, :post_type_id, :location_id])
  end

  def cast_content(changeset, %{content_type: content_type, id: id} = post, %{"content" => content} = attrs) do
    type = case content_type do
      %Ecto.Association.NotLoaded{} ->
        attrs
        |> Map.get("content_type_id")
        |> ContentType.name_for_id()
      _ -> Map.get(content_type, :name)
    end
    case type do
      "image" ->
        content = %{filename: "#{id}_content.png", binary: KidseeApiWeb.Avatar.decode!(content)}
        {:ok, url} = KidseeApiWeb.Avatar.store({content, post})
        cast(changeset, %{content: url}, [:content])
      _ -> cast(changeset, %{content: content}, [:content])
    end
  end

  def swagger_definitions do
    use PhoenixSwagger
    %{
      post: JsonApi.resource do
        description "A post"
        attributes do
          title :string, "Title of the post", required: true
          content :string, "the content of the post", required: true
          rating :float, "average rating of the post"
          rating_count :integer, "total ratings of the post"
        end
        relationship :user
        relationship :content_type
        relationship :post_type
        relationship :location
        relationship :status
        relationship :comments, type: :has_many
      end
    }
  end
end
