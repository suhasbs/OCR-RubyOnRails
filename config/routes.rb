Rails.application.routes.draw do
  get 'welocome/index'
  root 'welocome#index'
  get 'ocr/upload/' => 'ocr#upload'
  post 'ocr/upload/' => 'ocr#upload'
  get 'ocr/:id/get_coordinates/' => 'ocr#receive'
  post 'ocr/:id/predict_with_coordinates/' => 'ocr#resend'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
