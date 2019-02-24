module DidYouMean
  SPELL_CHECKERS.merge!({
    'SmartKv::KeyError' => KeyErrorChecker
  })

  ::SmartKv::KeyError.prepend DidYouMean::Correctable
end
