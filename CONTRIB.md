Dev environment requirements:
- Install Fit Commit, naturally: `gem install pre-commit; pre-commit install`

Development goals to reduce complexity:
- Minimize the logic in ActiveRecord models. Use service objects instead.
- No ActiveRecord callbacks.
- [DHH philosophy for controllers](http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/)
