using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationController : MonoBehaviour
{
    public Animator m_Animator;

    [SerializeField]
    private float m_WeightSmoothAim = 1.0f;
    [SerializeField]
    private float m_WeightSmoothHolster = 1.0f;
    [SerializeField]
    private GameObject m_arrow;

    private bool m_shoot = false;

    private bool m_arrowVisible = false;

    private float m_timer = 0.0f;

    static float t = 0.0f;
    static float s = 0.0f;

    private void Update()
    {
        if(m_arrowVisible)
            SetArrowVisible();
    }

    public void AnimationAirTimer(float _airTimer)
    {
        m_Animator.SetFloat("airTimer", _airTimer);
    }

    public void AnimationGround(bool _isGrounded)
    {
        m_Animator.SetBool("Grounded", _isGrounded);
    }

    public void AnimationJump(bool _isJumped)
    {
        m_Animator.SetBool("Jumped", _isJumped);
    }

    public void AnimationMovement(float _posX, float _posY)
    {
        m_Animator.SetFloat("PosX", _posX);
        m_Animator.SetFloat("PosY", _posY);
    }

    public void AnimationAiming(bool _isAiming)
    {
        if (_isAiming)
        {
            m_arrow.SetActive(true);
            m_timer += Time.deltaTime;
            s = 0;
            t += m_WeightSmoothAim * Time.deltaTime;
            m_Animator.SetLayerWeight(1, Mathf.Lerp(0f, 1f, t));
            //m_Animator.SetLayerWeight(2, Mathf.Lerp(0f, 1f, t));
            m_shoot = true;
        }
        else if (!_isAiming && m_shoot)
        {
            if (m_timer < 0.2)
            {
                m_Animator.SetTrigger("shootShort");
                m_arrow.SetActive(false);
            }
            else
            {
                m_Animator.SetTrigger("shootLong");
                m_arrow.SetActive(false);
            }
            m_shoot = false;
            m_timer = 0;
        }
        else
        {
            m_arrowVisible = true;
            t = 0;
            s += m_WeightSmoothHolster * Time.deltaTime;
            m_Animator.SetLayerWeight(1, Mathf.Lerp(1f, 0f, s));
            //m_Animator.SetLayerWeight(2, Mathf.Lerp(1f, 0f, s));
        }
    }

    public void SetArrowVisible()
    {
        m_timer += Time.deltaTime;

        if (m_timer > 0.7f)
        {
            m_arrow.SetActive(true);
            m_arrowVisible = false;
            m_timer = 0;
        }
    }

    public void AnimationAimAngle(float _angle)
    {
        m_Animator.SetFloat("AimX", _angle);
    }

}
