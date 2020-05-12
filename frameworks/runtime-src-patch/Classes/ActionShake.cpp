// https://github.com/bsy6766/Cocos2d-X-Shake-Action
#include "ActionShake.h"


ActionShake* ActionShake::create(float duration, float speed, float magnitude)
{
    ActionShake* ret = new (std::nothrow) ActionShake();
    if (ret && ret->initWithDuration(duration, speed, magnitude)) {
        ret->autorelease();
        return ret;
    }
    delete ret;
    return nullptr;
}

bool ActionShake::initWithDuration(float duration, float speed, float magnitude)
{
    bool ret = false;
    if (ActionInterval::initWithDuration(duration)) {
        _speed = speed;
        _magnitude = magnitude;
        ret = true;
    }
    return ret;
}

ActionShake* ActionShake::clone() const
{
    return ActionShake::create(_duration, _speed, _magnitude);
}

void ActionShake::startWithTarget(Node* target)
{
    ActionInterval::startWithTarget(target);
    this->_randomStart = RandomHelper::random_real(-1000.0f, 1000.0f);
}

void ActionShake::update(float time)
{
    if (this->_target == nullptr) return;

    float fDamper = 1.0f - clampf(2.0f * time - 1.0f, 0.0f, 1.0f);

    float fAlphaX = _randomStart + _speed * time;
    float fAlphaY = (_randomStart + 1000.0f) + _speed * time;

    // noise1 output range: -0.5 ~ 0.5
    float x = noise1(fAlphaX) * 2.0f; // mapping -1.0 ~ 1.0
    float y = noise1(fAlphaY) * 2.0f;

    x *= (_magnitude * fDamper);
    y *= (_magnitude * fDamper);

    Mat4 mat;
    mat.m[12] = x;
    mat.m[13] = y;
    mat.m[14] = 0.0f;
    mat.m[15] = 1.0f;

    if (this->_elapsed >= this->_duration) {
        _target->setAdditionalTransform(nullptr);
    }
	else {
        _target->setAdditionalTransform(&mat);
    }
}