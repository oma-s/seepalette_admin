FactoryBot.define do
  factory :expense do
    association :user
    date { 2.days.ago.to_date }
    start_address { "Seestraße 1, Dobbrikow" }
    end_address { "Bahnhofstraße 1, Potsdam" }
    purpose { "Einkauf" }
    km { 24 }
    factor { Expense::DEFAULT_FACTOR }
  end
end
