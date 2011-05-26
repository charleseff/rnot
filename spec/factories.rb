Factory.sequence(:title) { |n| "Title #{n}" }
Factory.sequence(:body) { |n| "Body of this document #{n}" }

Factory.define :note do |n|
  n.title { Factory.next(:title) }
  n.body { Factory.next(:body) }
end