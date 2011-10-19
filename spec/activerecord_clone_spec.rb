require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "ActiverecordClone" do
  context "clone_ar" do
    it "clone_ar no options" do
      post = Post.first
      clone = post.clone_ar
      clone.text.should include("Post!")
    end
    it "clone_ar exclude text" do
      post = Post.first
      clone = post.clone_ar :excluded => [:text]
      clone.text == nil
    end
    
  end

end