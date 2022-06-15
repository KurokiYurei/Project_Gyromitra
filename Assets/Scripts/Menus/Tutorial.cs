using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.UI;
using UnityEngine.Video;

public class Tutorial : MonoBehaviour
{
    [SerializeField]
    private Image m_image;

    [SerializeField]
    private bool m_playerIsInArea;

    [SerializeField]
    private Animation m_animation;

    [SerializeField]
    private GameObject m_player;

    [SerializeField]
    private float m_timer;

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            // StartCoroutine(WaitForHalfASecondCourotine());
            ShowTutorial();
            other.GetComponent<CharacterControllerScript>().enabled = false;
            other.GetComponent<WeaponController>().enabled = false;
            m_playerIsInArea = true;
        }
    }

    IEnumerator WaitForHalfASecondCourotine()
    {
        yield return new WaitForSeconds(0.5f);
    }

    private void Update()
    {
        if (m_player == null)
        {
            m_player = GameObject.FindGameObjectWithTag("Player");
        }

        if (m_playerIsInArea)
        {
            m_timer -= Time.deltaTime;
            if (m_timer <= 0f)
            {
                m_player.GetComponent<CharacterControllerScript>().enabled = true;
                m_player.GetComponent<WeaponController>().enabled = true;
                m_playerIsInArea = true;
                HideTutorial();
            }
        }
    }

    public void ShowTutorial()
    {
        gameObject.SetActive(true);
        m_animation.Play("TutorialShow");
    }

    public void HideTutorial()
    {
        m_animation.Play("TutorialHide");
        gameObject.SetActive(false);
    }

}
