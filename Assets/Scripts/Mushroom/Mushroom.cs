using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mushroom : MonoBehaviour
{
    private float m_timeToDestroy = 5.0f;
    private float m_currentTime;

    [SerializeField]
    private Vector3 targetscale;

    [SerializeField]
    private Animator m_animator;

    void Update()
    {
        if (m_currentTime >= m_timeToDestroy)
        {
            DestroyMushroom();
        }
        m_currentTime += Time.deltaTime;

        if (m_animator.GetCurrentAnimatorStateInfo(0).IsName("Appearing"))
        {
            transform.localScale = Vector3.Lerp(transform.localScale, targetscale, m_animator.GetCurrentAnimatorStateInfo(0).normalizedTime);
        }
    }

    public void DestroyMushroom()
    {
        gameObject.SetActive(false);
        CharacterControllerScript.GetMushroomPool().m_ActiveElementsList.RemoveAt(0);
        //CharacterControllerScript.GetMushroomPool().m_CurrentAmount -= 1;

        m_currentTime = 0.0f;
    }

    public void SetCurrentTime(float value)
    {
        m_currentTime = value;
    }

    public void PlayHorizontalBounceAnim()
    {
        m_animator.SetTrigger("HorizontalBounce");        
    }

    public void PlayVerticalBounceAnim()
    {
        m_animator.SetTrigger("VerticalBounce");
    }
}
