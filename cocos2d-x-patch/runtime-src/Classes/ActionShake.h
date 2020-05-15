#ifndef ACTION_SHAKE_H
#define ACTION_SHAKE_H

#include "cocos2d.h"

USING_NS_CC;

#define s_curve(t) (t * t * (3.0f - 2.0f * t))
#define lerp(t, a, b) (a + t * (b - a))

#define B 0x100
#define BM 0xff

#define N 0x1000
#define NP 12 /* 2^N */
#define NM 0xfff

static int p[B + B + 2];
//static float g3[B + B + 2][3];
//static float g2[B + B + 2][2];
static float g1[B + B + 2];
static int start = 1;

#define setup(i, b0, b1, r0, r1) \
    t = vec[i] + N;              \
    b0 = ((int)t) & BM;          \
    b1 = (b0 + 1) & BM;          \
    r0 = t - (int)t;             \
    r1 = r0 - 1.;

class ActionShake : public ActionInterval {
public:
    /**
	* Creates the action.
	*
	* @param duration Duration time, in seconds.
	* @param speed Speed of camera moving while shaking
	* @param magnitude The power of shaking
	* @return An autoreleased MoveBy object.
	*/
    static ActionShake* create(float duration, float speed, float magnitude);

    //
    // Overrides
    //
    virtual ActionShake* clone() const override;
    virtual void startWithTarget(Node* target) override;

    /**
	* @param time in seconds
	*/
    virtual void update(float time) override;

    CC_CONSTRUCTOR_ACCESS : ActionShake(){};
    virtual ~ActionShake(){};

    bool initWithDuration(float duration, float speed, float magnitude);

protected:
    float _speed;
    float _magnitude;
    float _randomStart;

    void init(void)
    {
        int i, j, k;

        for (i = 0; i < B; i++) {
            p[i] = i;

            float Bf = static_cast<float>(B);
            float rand = cocos2d::random();
            g1[i] = static_cast<float>((static_cast<int>(rand) % (B + B)) - B) / Bf;

            //for (j = 0 ; j < 2 ; j++)
            //	g2[i][j] = (float)((random() % (B + B)) - B) / B;
            //normalize2(g2[i]);

            //for (j = 0 ; j < 3 ; j++)
            //	g3[i][j] = (float)((random() % (B + B)) - B) / B;
            //normalize3(g3[i]);
        }

        while (--i) {
            k = p[i];
            p[i] = p[j = cocos2d::random() % B];
            p[j] = k;
        }

        for (i = 0; i < B + 2; i++) {
            p[B + i] = p[i];
            g1[B + i] = g1[i];
            //for (j = 0 ; j < 2 ; j++)
            //	g2[B + i][j] = g2[i][j];
            //for (j = 0 ; j < 3 ; j++)
            //	g3[B + i][j] = g3[i][j];
        }
    }

    double noise1(double arg)
    {
        int bx0, bx1;
        float rx0, rx1, sx, t, u, v, vec[1];

        vec[0] = arg;
        if (start) {
            start = 0;
            init();
        }

        setup(0, bx0, bx1, rx0, rx1);

        sx = s_curve(rx0);

        u = rx0 * g1[p[bx0]];
        v = rx1 * g1[p[bx1]];

        return lerp(sx, u, v);
    }

private:
    CC_DISALLOW_COPY_AND_ASSIGN(ActionShake);
};

#endif