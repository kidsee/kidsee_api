defmodule KidseeApi.PostFactory do
    use ExMachina.Ecto, repo: KidseeApi.Repo

    alias KidseeApi.Schemas.Post
    alias KidseeApi.{StatusFactory, ContentTypeFactory, PostTypeFactory, UserFactory, LocationFactory}

    use KidseeApi.JsonApiParamsStrategy, view: KidseeApiWeb.PostView

    def post_factory do
      %Post{
        content:      "Example content",
        location:     LocationFactory.insert(:location),
        title:        "Example title",
        status:       StatusFactory.insert(:status),
        content_type: ContentTypeFactory.insert(:content_type),
        post_type:    PostTypeFactory.insert(:post_type),
        user:         UserFactory.insert(:user),
        comments:     []
      }
    end

    def invalid_post_factory do
      %Post{build(:post) |
        user: nil
      }
    end

    def jsonapi_post_factory do
      json_api_params_for(:post)
    end
  end
